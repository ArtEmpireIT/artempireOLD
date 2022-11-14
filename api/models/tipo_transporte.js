/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('tipo_transporte', {
		nombre_tipo: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true
		},
		descripcion: {
			type: DataTypes.STRING,
			allowNull: true
		}
	}, {
		tableName: 'tipo_transporte',
		timestamps: false
	});
};
