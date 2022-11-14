/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('analysis', {
		id_analisis: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_analysis::regclass)",
			primaryKey: true
		},
		comments: {
			type: DataTypes.STRING,
			allowNull: true
		},
		distance_from_cervix: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		sub_name: {
			type: DataTypes.STRING,
			allowNull: true
		},
		ma_number: {
			type: DataTypes.INTEGER,
			allowNull: true
		},
		fk_sample_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'sample',
				key: 'id_muestra'
			}
		}
	}, {
		tableName: 'analysis',
		timestamps: false
	});
};
