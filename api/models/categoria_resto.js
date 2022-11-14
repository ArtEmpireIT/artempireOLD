/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('categoria_resto', {
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
		tableName: 'categoria_resto',
		timestamps: false
	});
};
