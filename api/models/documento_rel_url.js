/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('documento_rel_url', {
		fk_documento_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'documento',
				key: 'id_documento'
			}
		},
		fk_url_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'url',
				key: 'id_url'
			}
		},
		inicio_pag: {
			type: DataTypes.INTEGER,
			allowNull: true
		},
		fin_pag: {
			type: DataTypes.INTEGER,
			allowNull: true
		}
	}, {
		tableName: 'documento_rel_url',
		timestamps: false
	});
};
