module.exports = (sequelize, DataTypes) => {
  const PostTag = sequelize.define('PostTag', {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    post_id: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    tag: {
      type: DataTypes.STRING(100),
      allowNull: false
    }
  }, {
    tableName: 'post_tags',
    timestamps: false
  });

  return PostTag;
};
