/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('pena_rel_miembro', {
		fk_pena_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'pena',
				key: 'id_pena'
			}
		},
		fk_miembro_texto: {
			type: DataTypes.STRING,
			allowNull: false,
			references: {
				model: 'miembro',
				key: 'texto'
			}
		}
	}, {
		tableName: 'pena_rel_miembro',
		timestamps: false
	});
};
