/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('documento_rel_unidad', {
		fk_documento_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'documento',
				key: 'id_documento'
			}
		},
		fk_unidad_nombre: {
			type: DataTypes.STRING,
			allowNull: false,
			references: {
				model: 'unidad',
				key: 'nombre'
			}
		},
		valor: {
			type: DataTypes.DOUBLE,
			allowNull: false
		}
	}, {
		tableName: 'documento_rel_unidad',
		timestamps: false
	});
};
