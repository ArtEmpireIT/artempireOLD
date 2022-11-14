/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('paso_itinerario', {
		id_paso_itinerario: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_paso_itinerario::regclass)",
			primaryKey: true
		},
		fecha: {
			type: DataTypes.DATE,
			allowNull: true
		},
		tipo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		descripcion: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_navegacion_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'navegacion',
				key: 'id_navegacion'
			}
		},
		precision_paso: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_lugar_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'lugar',
				key: 'id_lugar'
			}
		}
	}, {
		tableName: 'paso_itinerario',
		timestamps: false
	});
};
