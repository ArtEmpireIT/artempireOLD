/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('anomalia', {
		id_anomalia: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_anomalia::regclass)",
			primaryKey: true
		},
		codigo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		nombre: {
			type: DataTypes.STRING,
			allowNull: true
		},
		descripcion: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_anomalia_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'anomalia',
				key: 'id_anomalia'
			}
		}
	}, {
		tableName: 'anomalia',
		timestamps: false
	});
};
