/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('sample', {
		id_muestra: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_muestra::regclass)",
			primaryKey: true
		},
		date: {
			type: DataTypes.DATE,
			allowNull: true
		},
		ma_number: {
			type: DataTypes.INTEGER,
			allowNull: true
		},
		recorder: {
			type: DataTypes.STRING,
			allowNull: true
		},
		overall_preservation: {
			type: DataTypes.STRING,
			allowNull: true
		},
		sediment_particles: {
			type: DataTypes.STRING,
			allowNull: true
		},
		microcracks: {
			type: DataTypes.STRING,
			allowNull: true
		},
		consistency: {
			type: DataTypes.STRING,
			allowNull: true
		},
		color: {
			type: DataTypes.STRING,
			allowNull: true
		},
		comments: {
			type: DataTypes.STRING,
			allowNull: true
		},
		name: {
			type: DataTypes.STRING,
			allowNull: true
		},
		material: {
			type: DataTypes.STRING,
			allowNull: true
		},
		crown_height: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		tooth_abrasion: {
			type: DataTypes.STRING,
			allowNull: true
		},
		surface: {
			type: DataTypes.STRING,
			allowNull: true
		},
		state: {
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
		},
		collector: {
			type: DataTypes.STRING,
			allowNull: true
		}
	}, {
		tableName: 'sample',
		timestamps: false
	});
};
