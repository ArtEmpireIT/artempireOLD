/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('entierro_rel_url', {
		fk_entierro_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'entierro',
				key: 'id_entierro'
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
		tableName: 'entierro_rel_url',
		timestamps: false
	});
};
