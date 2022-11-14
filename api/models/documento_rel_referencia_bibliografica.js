/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('documento_rel_referencia_bibliografica', {
		fk_documento_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'documento',
				key: 'id_documento'
			}
		},
		fk_referencia_bibliografica_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'referencia_bibliografica',
				key: 'id_referencia_bibliografica'
			}
		}
	}, {
		tableName: 'documento_rel_referencia_bibliografica',
		timestamps: false
	});
};
