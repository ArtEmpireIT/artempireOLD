/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('tipo_lugar_rel_lugar', {
		fk_tipo_lugar_nombre: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'tipo_lugar',
				key: 'nombre'
			}
		},
		fk_lugar_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'lugar',
				key: 'id_lugar'
			}
		}
	}, {
		tableName: 'tipo_lugar_rel_lugar',
		timestamps: false
	});
};
