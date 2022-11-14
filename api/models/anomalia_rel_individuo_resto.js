/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('anomalia_rel_individuo_resto', {
		fk_anomalia_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'anomalia',
				key: 'id_anomalia'
			}
		},
		fk_individuo_resto_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'individuo_lote_resto',
				key: 'id_individuo_resto'
			}
		}
	}, {
		tableName: 'anomalia_rel_individuo_resto',
		timestamps: false
	});
};
