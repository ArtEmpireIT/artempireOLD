/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('collagen', {
		id_collagen: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_collagen::regclass)",
			primaryKey: true
		},
		collagen_yield: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		cp: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		cp_1sd: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		np: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		np_1sd: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		atomic_cn_ratio: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		s13_ccoll: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		s13_ccoll_1sd: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		s15_ncoll: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		s15_ncoll_1sd: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		quality_criteria: {
			type: DataTypes.STRING,
			allowNull: true
		},
		quality_comment: {
			type: DataTypes.STRING,
			allowNull: true
		},
		comments: {
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
		}
	}, {
		tableName: 'collagen',
		timestamps: false
	});
};
