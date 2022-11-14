/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('especie', {
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
		tableName: 'especie',
		timestamps: false
	});
};
