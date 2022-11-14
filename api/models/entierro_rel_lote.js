/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('entierro_rel_lote', {
		fk_entierro_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'entierro',
				key: 'id_entierro'
			}
		},
		fk_lote_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'lote',
				key: 'id_lote'
			}
		}
	}, {
		tableName: 'entierro_rel_lote',
		timestamps: false
	});
};
