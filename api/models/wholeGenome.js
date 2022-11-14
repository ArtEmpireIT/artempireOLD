/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('wholeGenome', {
		id_wholeGenome: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_wholegenome::regclass)",
			primaryKey: true
		},
		fk_dniaextraction_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'dna_extraction',
				key: 'id_dna_extraction'
			}
		},
		ances_origin: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fastA: {
			type: DataTypes.STRING,
			allowNull: true
		},
		seq_strategy: {
			type: DataTypes.STRING,
			allowNull: true
		},
		libraries_seq: {
			type: DataTypes.STRING,
			allowNull: true
		},
		raw_reads: {
			type: DataTypes.INTEGER,
			allowNull: true
		},
		merged_reads: {
			type: DataTypes.INTEGER,
			allowNull: true
		},
		mapped_reads: {
			type: DataTypes.INTEGER,
			allowNull: true
		},
		whole_coverage: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		mean_read_depth: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		// 3deamination: {
		// 	type: DataTypes.DOUBLE,
		// 	allowNull: true
		// },
		// 5deamination: {
		// 	type: DataTypes.DOUBLE,
		// 	allowNull: true
		// },
		insert_size: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		contamination: {
			type: DataTypes.STRING,
			allowNull: true
		},
		comments: {
			type: DataTypes.STRING,
			allowNull: true
		},
		interpretation: {
			type: DataTypes.STRING,
			allowNull: true
		}
	}, {
		tableName: 'wholeGenome',
		timestamps: false
	});
};
