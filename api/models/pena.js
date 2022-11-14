/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('pena', {
		id_pena: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_pena::regclass)",
			primaryKey: true
		},
		destierro_tipo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fecha_ini_dest: {
			type: DataTypes.DATE,
			allowNull: true
		},
		fecha_fin_dest: {
			type: DataTypes.DATE,
			allowNull: true
		},
		precision_ini_dest: {
			type: DataTypes.STRING,
			allowNull: true
		},
		precision_fin_dest: {
			type: DataTypes.STRING,
			allowNull: true
		},
		multa: {
			type: DataTypes.BOOLEAN,
			allowNull: true
		},
		destierro: {
			type: DataTypes.BOOLEAN,
			allowNull: true
		},
		exculpatoria: {
			type: DataTypes.BOOLEAN,
			allowNull: true
		},
		perdida_bienes: {
			type: DataTypes.BOOLEAN,
			allowNull: true
		},
		perdida_bienes_desc: {
			type: DataTypes.STRING,
			allowNull: true
		},
		otro: {
			type: DataTypes.BOOLEAN,
			allowNull: true
		},
		otro_desc: {
			type: DataTypes.STRING,
			allowNull: true
		},
		escarnio: {
			type: DataTypes.BOOLEAN,
			allowNull: true
		},
		azotes: {
			type: DataTypes.BOOLEAN,
			allowNull: true
		},
		muerte: {
			type: DataTypes.BOOLEAN,
			allowNull: true
		},
		muerte_medio: {
			type: DataTypes.STRING,
			allowNull: true
		}
	}, {
		tableName: 'pena',
		timestamps: false
	});
};
