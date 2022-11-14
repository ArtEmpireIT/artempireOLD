/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('metodo_pago', {
		id_metodo_pago: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_metodo_pago::regclass)",
			primaryKey: true
		},
		tipo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		plazo_credito: {
			type: DataTypes.STRING,
			allowNull: true
		},
		interes_credito: {
			type: DataTypes.STRING,
			allowNull: true
		}
	}, {
		tableName: 'metodo_pago',
		timestamps: false
	});
};
