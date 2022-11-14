/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('lote_rel_url', {
		fk_lote_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'lote',
				key: 'id_lote'
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
		tableName: 'lote_rel_url',
		timestamps: false
	});
};
