const mysql = require('mysql2/promise');

(async () => {
  const conn = await mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'sosialkita_db'
  });

  // Lihat semua index pada tabel users
  const [allIndexes] = await conn.query('SHOW INDEX FROM users');
  const indexNames = allIndexes.map(r => r.Key_name);
  console.log('All indexes:', JSON.stringify(indexNames));

  // Cari duplikat: index pada username dan email yang bukan 'username' atau 'email' (asli)
  const duplicates = [...new Set(indexNames)].filter(name => {
    return name !== 'PRIMARY' && name !== 'username' && name !== 'email' && 
           (name.startsWith('username_') || name.startsWith('email_') || 
            name.startsWith('users_') || /^username\d+$/.test(name) || /^email\d+$/.test(name));
  });

  console.log('Duplicates to drop:', duplicates);

  // Hapus semua duplikat
  for (const idx of duplicates) {
    try {
      await conn.query(`ALTER TABLE users DROP INDEX \`${idx}\``);
      console.log(`  Dropped: ${idx}`);
    } catch (e) {
      console.log(`  Skip ${idx}: ${e.message}`);
    }
  }

  // Juga cek tabel lain
  for (const table of ['posts', 'comments', 'likes', 'follows', 'saved_posts', 'stories', 'messages']) {
    try {
      const [tableIndexes] = await conn.query(`SHOW INDEX FROM ${table}`);
      const names = tableIndexes.map(r => r.Key_name);
      const uniqueNames = [...new Set(names)];
      // Count how many times each index appears
      const counts = {};
      names.forEach(n => { counts[n] = (counts[n] || 0) + 1; });
      const total = uniqueNames.length;
      if (total > 10) {
        console.log(`\n${table}: ${total} indexes (may need cleanup)`);
      }
    } catch (e) {
      // table might not exist
    }
  }

  // Sekarang coba drop semua index yang bukan PRIMARY dan bukan nama field asli pada users
  // Ambil ulang
  const [remaining] = await conn.query('SHOW INDEX FROM users');
  const remainingNames = [...new Set(remaining.map(r => r.Key_name))];
  console.log('\nRemaining indexes on users:', remainingNames);
  
  // Kita hanya perlu: PRIMARY, username, email
  // Hapus sisanya
  for (const idx of remainingNames) {
    if (idx === 'PRIMARY' || idx === 'username' || idx === 'email') continue;
    try {
      await conn.query(`ALTER TABLE users DROP INDEX \`${idx}\``);
      console.log(`  Dropped extra: ${idx}`);
    } catch (e) {
      console.log(`  Skip ${idx}: ${e.message}`);
    }
  }

  const [final_] = await conn.query('SHOW INDEX FROM users');
  console.log('\nFinal indexes:', [...new Set(final_.map(r => r.Key_name))]);

  await conn.end();
  console.log('\nDone!');
})();
