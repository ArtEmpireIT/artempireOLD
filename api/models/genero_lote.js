/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('genero_lote', {
		nombre: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true
		}
	}, {
		tableName: 'genero_lote',
		timestamps: false
	});
};
