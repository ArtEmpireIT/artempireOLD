/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('sr', {
		id_sr: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_sr::regclass)",
			primaryKey: true
		},
		sr_concentration: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		d87sr_86sr: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		d87sr_86sr_2sd: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		comments: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_analysis_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			references: {
				model: 'analysis',
				key: 'id_analisis'
			}
		}
	}, {
		tableName: 'sr',
		timestamps: false
	});
};
