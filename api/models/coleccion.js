/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('coleccion', {
		sigla: {
			type: DataTypes.STRING,
			allowNull: false
		},
		tipo: {
			type: DataTypes.STRING,
			allowNull: false
		},
		descripcion: {
			type: DataTypes.STRING,
			allowNull: true
		},
		nombre: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true
		}
	}, {
		tableName: 'coleccion',
		timestamps: false
	});
};
