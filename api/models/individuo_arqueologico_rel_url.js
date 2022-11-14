/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('individuo_arqueologico_rel_url', {
		fk_individuo_arqueologico_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'individuo_arqueologico',
				key: 'id_individuo_arqueologico'
			}
		},
		fk_url_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'url',
				key: 'id_url'
			}
		}
	}, {
		tableName: 'individuo_arqueologico_rel_url',
		timestamps: false
	});
};
