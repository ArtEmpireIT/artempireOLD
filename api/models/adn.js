/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('adn', {
		id_adn: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_adn::regclass)",
			primaryKey: true
		},
		library_id: {
			type: DataTypes.STRING,
			allowNull: true
		},
		collection_num: {
			type: DataTypes.STRING,
			allowNull: true
		},
		site_name: {
			type: DataTypes.STRING,
			allowNull: true
		},
		archeology: {
			type: DataTypes.STRING,
			allowNull: true
		},
		id2: {
			type: DataTypes.STRING,
			allowNull: true
		},
		material: {
			type: DataTypes.STRING,
			allowNull: true
		},
		c14: {
			type: DataTypes.STRING,
			allowNull: true
		},
		date_interval: {
			type: DataTypes.STRING,
			allowNull: true
		},
		haplotype: {
			type: DataTypes.STRING,
			allowNull: true
		},
		haplogroup: {
			type: DataTypes.STRING,
			allowNull: true
		},
		raw_reads: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		marged_reads: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		mapped_reads: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		duplicate_removal_mapp: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		average_coverage: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		d3_deamination: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		d5_deamination: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		insert_size: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		contamination_estimate: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_muestra_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'muestra',
				key: 'id_muestra'
			}
		}
	}, {
		tableName: 'adn',
		timestamps: false
	});
};
