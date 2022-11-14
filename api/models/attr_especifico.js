/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('attr_especifico', {
		id_attr_especifico: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_attr_especifico::regclass)",
			primaryKey: true
		},
		nombre: {
			type: DataTypes.STRING,
			allowNull: true
		},
		tipo: {
			type: DataTypes.STRING,
			allowNull: true
		}
	}, {
		tableName: 'attr_especifico',
		timestamps: false
	});
};
