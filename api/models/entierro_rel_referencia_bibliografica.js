/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('entierro_rel_referencia_bibliografica', {
		fk_entierro_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'entierro',
				key: 'id_entierro'
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
		tableName: 'entierro_rel_referencia_bibliografica',
		timestamps: false
	});
};
