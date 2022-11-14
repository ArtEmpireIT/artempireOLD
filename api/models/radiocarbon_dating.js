/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('radiocarbon_dating', {
		id_radiocarbon_dating: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_radiocarbon_dating::regclass)",
			primaryKey: true
		},
		c_age_bp: {
			type: DataTypes.STRING,
			allowNull: true
		},
		years: {
			type: DataTypes.INTEGER,
			allowNull: true
		},
		calibrated_date_1s: {
			type: DataTypes.STRING,
			allowNull: true
		},
		calibrated_date_2s: {
			type: DataTypes.STRING,
			allowNull: true
		},
		s13: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		cn: {
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
		tableName: 'radiocarbon_dating',
		timestamps: false
	});
};
