/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('individuo_arqueologico', {
		id_individuo_arqueologico: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_individuo_arqueologico::regclass)",
			primaryKey: true
		},
		catalogo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		individuo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		genero: {
			type: DataTypes.STRING,
			allowNull: true
		},
		edad: {
			type: DataTypes.STRING,
			allowNull: true
		},
		edad_recodificada: {
			type: DataTypes.STRING,
			allowNull: true
		},
		filiacion_poblacional: {
			type: DataTypes.STRING,
			allowNull: true
		},
		estatura: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		fecha_inicio: {
			type: DataTypes.DATE,
			allowNull: true
		},
		precision_inicio: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fecha_fin: {
			type: DataTypes.DATE,
			allowNull: true
		},
		precision_fin: {
			type: DataTypes.STRING,
			allowNull: true
		},
		c13c_12c: {
			type: DataTypes.STRING,
			allowNull: true
		},
		codigo_14c: {
			type: DataTypes.STRING,
			allowNull: true
		},
		unid_estratigrafica: {
			type: DataTypes.STRING,
			allowNull: true
		},
		unid_estratigrafica_asociada: {
			type: DataTypes.STRING,
			allowNull: true
		},
		tipo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		clase_enterramiento: {
			type: DataTypes.STRING,
			allowNull: true
		},
		periodo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		cal: {
			type: DataTypes.STRING,
			allowNull: true
		},
		descomposicion: {
			type: DataTypes.STRING,
			allowNull: true
		},
		contenedor: {
			type: DataTypes.STRING,
			allowNull: true
		},
		pos_extremidades_inf: {
			type: DataTypes.STRING,
			allowNull: true
		},
		pos_extremidades_sup: {
			type: DataTypes.STRING,
			allowNull: true
		},
		posicion_cuerpo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		orientacion_cuerpo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		orientacion_creaneo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		chronological_affiliation: {
			type: DataTypes.STRING,
			allowNull: true
		}
	}, {
		tableName: 'individuo_arqueologico',
		timestamps: false
	});
};
