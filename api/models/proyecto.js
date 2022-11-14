/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('proyecto', {
		nombre: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true
		},
		descripcion: {
			type: DataTypes.STRING,
			allowNull: true
		}
	}, {
		tableName: 'proyecto',
		timestamps: false
	});
};
