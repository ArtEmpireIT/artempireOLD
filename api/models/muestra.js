/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('muestra', {
		id_muestra: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_muestra::regclass)",
			primaryKey: true
		},
		fecha: {
			type: DataTypes.DATE,
			allowNull: true
		},
		num_muestra: {
			type: DataTypes.INTEGER,
			allowNull: true
		},
		afiliacion_cronologica: {
			type: DataTypes.STRING,
			allowNull: true
		},
		grabadora: {
			type: DataTypes.STRING,
			allowNull: true
		},
		preservacion_general: {
			type: DataTypes.STRING,
			allowNull: true
		},
		particulas_sedimento: {
			type: DataTypes.STRING,
			allowNull: true
		},
		microgrietas: {
			type: DataTypes.STRING,
			allowNull: true
		},
		consistencia: {
			type: DataTypes.STRING,
			allowNull: true
		},
		color: {
			type: DataTypes.STRING,
			allowNull: true
		},
		observaciones: {
			type: DataTypes.STRING,
			allowNull: true
		},
		nombre: {
			type: DataTypes.STRING,
			allowNull: true
		},
		sub_nombre: {
			type: DataTypes.STRING,
			allowNull: true
		},
		material: {
			type: DataTypes.STRING,
			allowNull: true
		},
		altura_corona: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		abrasion_dental: {
			type: DataTypes.STRING,
			allowNull: true
		},
		superficie: {
			type: DataTypes.STRING,
			allowNull: true
		},
		estado: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_individuo_resto_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'individuo_lote_resto',
				key: 'id_individuo_resto'
			}
		}
	}, {
		tableName: 'muestra',
		timestamps: false
	});
};
