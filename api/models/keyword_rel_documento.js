/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('keyword_rel_documento', {
		fk_keyword_palabra: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'keyword',
				key: 'palabra'
			}
		},
		fk_documento_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'documento',
				key: 'id_documento'
			}
		}
	}, {
		tableName: 'keyword_rel_documento',
		timestamps: false
	});
};
