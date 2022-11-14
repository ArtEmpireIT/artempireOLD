/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('maps', {
		id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id::regclass)",
			primaryKey: true
		},
		title: {
			type: DataTypes.STRING,
			allowNull: true
		},
		description: {
			type: DataTypes.STRING,
			allowNull: true
        },
		link: {
			type: DataTypes.STRING,
			allowNull: true
		}
	}, {
		tableName: 'maps',
		timestamps: false
	});
};
