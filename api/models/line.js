/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('line', {
		geom_wgs84: {
			type: DataTypes.ENUM(),
			allowNull: true
		},
		id_line: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_line::regclass)",
			primaryKey: true
		},
		geom_nad27: {
			type: DataTypes.ENUM(),
			allowNull: true
		}
	}, {
		tableName: 'line',
		timestamps: false
	});
};
