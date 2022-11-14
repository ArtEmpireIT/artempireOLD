/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('objeto', {
		id_objeto: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_objeto::regclass)",
			primaryKey: true
		},
		tipo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		nombre: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_objeto_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'objeto',
				key: 'id_objeto'
			}
		}
	}, {
		tableName: 'objeto',
		timestamps: false
	});
};
