/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('dna_extraction', {
		id_dna_extraction: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_dna_extraction::regclass)",
			primaryKey: true
		},
		sample_name: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_analysis_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'analysis',
				key: 'id_analisis'
			}
		},
		unipv_number: {
			type: DataTypes.INTEGER,
			allowNull: true
		},
		skeletal: {
			type: DataTypes.STRING,
			allowNull: true
		},
		surface: {
			type: DataTypes.STRING,
			allowNull: true
		},
		overall: {
			type: DataTypes.STRING,
			allowNull: true
		},
		date: {
			type: DataTypes.DATE,
			allowNull: true
		},
		recorder: {
			type: DataTypes.STRING,
			allowNull: true
		},
		concentration: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		ratio: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		comments: {
			type: DataTypes.STRING,
			allowNull: true
		}
	}, {
		tableName: 'dna_extraction',
		timestamps: false
	});
};
