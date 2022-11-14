/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('estado', {
		tipo_cons_represen: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true
		},
		elemento: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true
		}
	}, {
		tableName: 'estado',
		timestamps: false
	});
};
