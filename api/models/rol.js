/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('rol', {
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
		tableName: 'rol',
		timestamps: false
	});
};
