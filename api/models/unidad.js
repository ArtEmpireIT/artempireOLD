/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('unidad', {
		nombre: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true
		},
		tipo: {
			type: DataTypes.STRING,
			allowNull: true
		}
	}, {
		tableName: 'unidad',
		timestamps: false
	});
};
