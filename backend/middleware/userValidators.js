const { param, query } = require('express-validator');

const userIdParamRules = [param('id').isMongoId().withMessage('Invalid user id')];

const listUsersRules = [
  query('page').optional().isInt({ min: 1 }).withMessage('page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('limit must be between 1 and 100'),
];

module.exports = { userIdParamRules, listUsersRules };
