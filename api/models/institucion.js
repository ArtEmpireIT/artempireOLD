/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('institucion', {
		nombre: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true
		},
		fecha_creacion: {
			type: DataTypes.DATE,
			allowNull: true
		},
		descripcion: {
			type: DataTypes.STRING,
			allowNull: true
		}
	}, {
		tableName: 'institucion',
		timestamps: false
	});
};
