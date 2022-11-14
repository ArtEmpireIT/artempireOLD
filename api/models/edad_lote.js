/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('edad_lote', {
		nombre: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true
		},
		edad: {
			type: DataTypes.STRING,
			allowNull: true
		}
	}, {
		tableName: 'edad_lote',
		timestamps: false
	});
};
