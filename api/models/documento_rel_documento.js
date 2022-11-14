/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('documento_rel_documento', {
		fk_documento1: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'documento',
				key: 'id_documento'
			}
		},
		fk_documento2: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'documento',
				key: 'id_documento'
			}
		}
	}, {
		tableName: 'documento_rel_documento',
		timestamps: false
	});
};
