/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('proyecto_rel_documento', {
		fk_proyecto_nombre: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'proyecto',
				key: 'nombre'
			}
		},
		fk_documento_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'documento',
				key: 'id_documento'
			}
		}
	}, {
		tableName: 'proyecto_rel_documento',
		timestamps: false
	});
};
