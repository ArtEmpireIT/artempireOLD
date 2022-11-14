/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('keyword', {
		palabra: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true
		},
		key_indice: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_keyword: {
			type: DataTypes.STRING,
			allowNull: true,
			references: {
				model: 'keyword',
				key: 'palabra'
			}
		}
	}, {
		tableName: 'keyword',
		timestamps: false
	});
};
