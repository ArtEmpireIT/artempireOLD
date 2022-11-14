/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('phosphates', {
		id_phosphates: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_phosphates::regclass)",
			primaryKey: true
		},
		phosphate_yield: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		s18op: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		s18op_1sd: {
			type: DataTypes.DOUBLE,
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
		tableName: 'phosphates',
		timestamps: false
	});
};
