/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('polygon', {
		geom_wgs84: {
			type: DataTypes.ENUM(),
			allowNull: true
		},
		id_polygon: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_polygon::regclass)",
			primaryKey: true
		},
		geom_nad27: {
			type: DataTypes.ENUM(),
			allowNull: true
		}
	}, {
		tableName: 'polygon',
		timestamps: false
	});
};
