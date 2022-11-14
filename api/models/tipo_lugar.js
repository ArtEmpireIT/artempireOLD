/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('tipo_lugar', {
		nombre: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true
		},
		fk_tipo_lugar: {
			type: DataTypes.STRING,
			allowNull: true,
			references: {
				model: 'tipo_lugar',
				key: 'nombre'
			}
		}
	}, {
		tableName: 'tipo_lugar',
		timestamps: false
	});
};
