/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('material', {
		id_material: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_material::regclass)",
			primaryKey: true
		},
		nombre: {
			type: DataTypes.STRING,
			allowNull: false
		},
		fk_material_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'material',
				key: 'id_material'
			}
		}
	}, {
		tableName: 'material',
		timestamps: false
	});
};
