/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('carbonate', {
		id_carbonate: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_carbonate::regclass)",
			primaryKey: true
		},
		s18oc: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		s18oc_1sd: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		s13cc: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		s13cc_1sd: {
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
		tableName: 'carbonate',
		timestamps: false
	});
};
