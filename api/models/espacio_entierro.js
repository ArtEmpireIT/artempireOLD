/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('espacio_entierro', {
		nombre: {
			type: DataTypes.STRING,
			allowNull: false,
			primaryKey: true
		},
		fk_espacio_entierro: {
			type: DataTypes.STRING,
			allowNull: true,
			references: {
				model: 'espacio_entierro',
				key: 'nombre'
			}
		}
	}, {
		tableName: 'espacio_entierro',
		timestamps: false
	});
};
