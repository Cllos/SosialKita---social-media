const { Sequelize, DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

// Import model definitions
const User = require('./User')(sequelize, DataTypes);
const Post = require('./Post')(sequelize, DataTypes);
const PostTag = require('./PostTag')(sequelize, DataTypes);
const Comment = require('./Comment')(sequelize, DataTypes);
const Like = require('./Like')(sequelize, DataTypes);
const Follow = require('./Follow')(sequelize, DataTypes);
const SavedPost = require('./SavedPost')(sequelize, DataTypes);
const Story = require('./Story')(sequelize, DataTypes);
const Message = require('./Message')(sequelize, DataTypes);

// ── Asosiasi ──

// User <-> Post
User.hasMany(Post, { foreignKey: 'user_id', as: 'posts' });
Post.belongsTo(User, { foreignKey: 'user_id', as: 'author' });

// Post <-> PostTag
Post.hasMany(PostTag, { foreignKey: 'post_id', as: 'tags' });
PostTag.belongsTo(Post, { foreignKey: 'post_id' });

// User <-> Comment
User.hasMany(Comment, { foreignKey: 'user_id' });
Comment.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

// Post <-> Comment
Post.hasMany(Comment, { foreignKey: 'post_id', as: 'comments' });
Comment.belongsTo(Post, { foreignKey: 'post_id' });

// User <-> Like
User.hasMany(Like, { foreignKey: 'user_id' });
Like.belongsTo(User, { foreignKey: 'user_id' });

// Post <-> Like
Post.hasMany(Like, { foreignKey: 'post_id', as: 'likes' });
Like.belongsTo(Post, { foreignKey: 'post_id' });

// Follow (self-referencing User)
User.belongsToMany(User, { through: Follow, as: 'followers', foreignKey: 'following_id', otherKey: 'follower_id' });
User.belongsToMany(User, { through: Follow, as: 'following', foreignKey: 'follower_id', otherKey: 'following_id' });
Follow.belongsTo(User, { foreignKey: 'follower_id', as: 'follower' });
Follow.belongsTo(User, { foreignKey: 'following_id', as: 'followingUser' });

// User <-> SavedPost
User.hasMany(SavedPost, { foreignKey: 'user_id' });
SavedPost.belongsTo(User, { foreignKey: 'user_id' });

// Post <-> SavedPost
Post.hasMany(SavedPost, { foreignKey: 'post_id' });
SavedPost.belongsTo(Post, { foreignKey: 'post_id', as: 'post' });

// User <-> Story
User.hasMany(Story, { foreignKey: 'user_id', as: 'stories' });
Story.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

// User <-> Message (sender & receiver)
User.hasMany(Message, { foreignKey: 'sender_id', as: 'sentMessages' });
User.hasMany(Message, { foreignKey: 'receiver_id', as: 'receivedMessages' });
Message.belongsTo(User, { foreignKey: 'sender_id', as: 'sender' });
Message.belongsTo(User, { foreignKey: 'receiver_id', as: 'receiver' });

module.exports = {
  sequelize,
  Sequelize,
  User,
  Post,
  PostTag,
  Comment,
  Like,
  Follow,
  SavedPost,
  Story,
  Message
};
