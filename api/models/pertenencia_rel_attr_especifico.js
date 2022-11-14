/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('pertenencia_rel_attr_especifico', {
		fk_pertenencia_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'pertenencia',
				key: 'id_pertenencia'
			}
		},
		fk_attr_especifico_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'attr_especifico',
				key: 'id_attr_especifico'
			}
		}
	}, {
		tableName: 'pertenencia_rel_attr_especifico',
		timestamps: false
	});
};
