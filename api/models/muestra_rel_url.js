/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('muestra_rel_url', {
		fk_muestra_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'sample',
				key: 'id_muestra'
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
		tableName: 'muestra_rel_url',
		timestamps: false
	});
};
